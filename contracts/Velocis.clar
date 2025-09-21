;; Velocis - Decentralized Social Media Platform
;; A trustless social interaction platform built on Stacks with IPFS media support

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_INPUT (err u400))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant MIN_TIP_AMOUNT u1000000) ;; 1 STX in microSTX

;; Media type constants
(define-constant MEDIA_TYPE_TEXT u0)
(define-constant MEDIA_TYPE_IMAGE u1)
(define-constant MEDIA_TYPE_VIDEO u2)
(define-constant MEDIA_TYPE_AUDIO u3)
(define-constant MEDIA_TYPE_DOCUMENT u4)

;; Data Variables
(define-data-var next-post-id uint u1)
(define-data-var platform-fee uint u100) ;; 1% in basis points
(define-data-var total-platform-earnings uint u0)

;; Data Maps
(define-map posts 
  { post-id: uint }
  { 
    author: principal,
    content: (string-ascii 280),
    timestamp: uint,
    likes: uint,
    tips-received: uint,
    active: bool,
    media-type: uint,
    ipfs-hash: (optional (string-ascii 100)),
    media-metadata: (optional (string-ascii 200))
  }
)

(define-map user-profiles
  { user: principal }
  {
    username: (string-ascii 50),
    bio: (string-ascii 200),
    followers: uint,
    following: uint,
    posts-count: uint,
    total-tips-received: uint,
    total-tips-sent: uint,
    created-at: uint,
    avatar-ipfs-hash: (optional (string-ascii 100))
  }
)

(define-map post-likes
  { post-id: uint, user: principal }
  { liked: bool }
)

(define-map user-follows
  { follower: principal, following: principal }
  { active: bool }
)

(define-map user-posts
  { user: principal, post-index: uint }
  { post-id: uint }
)

(define-map post-tips
  { post-id: uint, tipper: principal }
  { 
    amount: uint,
    timestamp: uint
  }
)

(define-map post-media-views
  { post-id: uint }
  { 
    view-count: uint,
    last-updated: uint
  }
)

;; Private Functions
(define-private (is-valid-string (str (string-ascii 280)))
  (and (> (len str) u0) (<= (len str) u280))
)

(define-private (is-valid-username (username (string-ascii 50)))
  (and (> (len username) u2) (<= (len username) u50))
)

(define-private (is-valid-post-id (post-id uint))
  (and (> post-id u0) (< post-id (var-get next-post-id)))
)

(define-private (is-valid-tip-amount (amount uint))
  (>= amount MIN_TIP_AMOUNT)
)

(define-private (is-valid-media-type (media-type uint))
  (and (>= media-type MEDIA_TYPE_TEXT) (<= media-type MEDIA_TYPE_DOCUMENT))
)

(define-private (is-valid-ipfs-hash (ipfs-hash (string-ascii 100)))
  (and (> (len ipfs-hash) u0) (<= (len ipfs-hash) u100))
)

(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee)) u10000)
)

;; Read-Only Functions
(define-read-only (get-post (post-id uint))
  (if (is-valid-post-id post-id)
    (map-get? posts { post-id: post-id })
    none
  )
)

(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles { user: user })
)

(define-read-only (has-liked-post (post-id uint) (user principal))
  (if (is-valid-post-id post-id)
    (default-to false (get liked (map-get? post-likes { post-id: post-id, user: user })))
    false
  )
)

(define-read-only (is-following (follower principal) (following principal))
  (default-to false (get active (map-get? user-follows { follower: follower, following: following })))
)

(define-read-only (get-next-post-id)
  (var-get next-post-id)
)

(define-read-only (get-user-post-by-index (user principal) (index uint))
  (map-get? user-posts { user: user, post-index: index })
)

(define-read-only (get-platform-fee)
  (var-get platform-fee)
)

(define-read-only (get-total-platform-earnings)
  (var-get total-platform-earnings)
)

(define-read-only (get-post-tip (post-id uint) (tipper principal))
  (if (is-valid-post-id post-id)
    (map-get? post-tips { post-id: post-id, tipper: tipper })
    none
  )
)

(define-read-only (get-min-tip-amount)
  MIN_TIP_AMOUNT
)

(define-read-only (get-post-media-views (post-id uint))
  (if (is-valid-post-id post-id)
    (map-get? post-media-views { post-id: post-id })
    none
  )
)

(define-read-only (get-media-type-constants)
  {
    text: MEDIA_TYPE_TEXT,
    image: MEDIA_TYPE_IMAGE,
    video: MEDIA_TYPE_VIDEO,
    audio: MEDIA_TYPE_AUDIO,
    document: MEDIA_TYPE_DOCUMENT
  }
)

;; Public Functions
(define-public (create-profile (username (string-ascii 50)) (bio (string-ascii 200)))
  (let (
    (existing-profile (map-get? user-profiles { user: tx-sender }))
  )
    (asserts! (is-none existing-profile) ERR_ALREADY_EXISTS)
    (asserts! (is-valid-username username) ERR_INVALID_INPUT)
    (asserts! (<= (len bio) u200) ERR_INVALID_INPUT)
    (ok (map-set user-profiles 
      { user: tx-sender }
      {
        username: username,
        bio: bio,
        followers: u0,
        following: u0,
        posts-count: u0,
        total-tips-received: u0,
        total-tips-sent: u0,
        created-at: stacks-block-height,
        avatar-ipfs-hash: none
      }
    ))
  )
)

(define-public (update-profile-avatar (avatar-ipfs-hash (string-ascii 100)))
  (let (
    (user-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR_NOT_FOUND))
  )
    (asserts! (is-valid-ipfs-hash avatar-ipfs-hash) ERR_INVALID_INPUT)
    (ok (map-set user-profiles 
      { user: tx-sender }
      (merge user-profile { avatar-ipfs-hash: (some avatar-ipfs-hash) })
    ))
  )
)

(define-public (create-post (content (string-ascii 280)))
  (let (
    (post-id (var-get next-post-id))
    (user-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR_NOT_FOUND))
    (current-posts-count (get posts-count user-profile))
  )
    (asserts! (is-valid-string content) ERR_INVALID_INPUT)
    (map-set posts 
      { post-id: post-id }
      {
        author: tx-sender,
        content: content,
        timestamp: stacks-block-height,
        likes: u0,
        tips-received: u0,
        active: true,
        media-type: MEDIA_TYPE_TEXT,
        ipfs-hash: none,
        media-metadata: none
      }
    )
    (map-set user-posts 
      { user: tx-sender, post-index: current-posts-count }
      { post-id: post-id }
    )
    (map-set user-profiles 
      { user: tx-sender }
      (merge user-profile { posts-count: (+ current-posts-count u1) })
    )
    (var-set next-post-id (+ post-id u1))
    (ok post-id)
  )
)

(define-public (create-media-post 
  (content (string-ascii 280)) 
  (media-type uint) 
  (ipfs-hash (string-ascii 100)) 
  (media-metadata (optional (string-ascii 200))))
  (let (
    (post-id (var-get next-post-id))
    (user-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR_NOT_FOUND))
    (current-posts-count (get posts-count user-profile))
  )
    (asserts! (is-valid-string content) ERR_INVALID_INPUT)
    (asserts! (is-valid-media-type media-type) ERR_INVALID_INPUT)
    (asserts! (is-valid-ipfs-hash ipfs-hash) ERR_INVALID_INPUT)
    (asserts! (if (is-some media-metadata)
      (<= (len (unwrap-panic media-metadata)) u200)
      true) ERR_INVALID_INPUT)
    
    (map-set posts 
      { post-id: post-id }
      {
        author: tx-sender,
        content: content,
        timestamp: stacks-block-height,
        likes: u0,
        tips-received: u0,
        active: true,
        media-type: media-type,
        ipfs-hash: (some ipfs-hash),
        media-metadata: media-metadata
      }
    )
    (map-set user-posts 
      { user: tx-sender, post-index: current-posts-count }
      { post-id: post-id }
    )
    (map-set user-profiles 
      { user: tx-sender }
      (merge user-profile { posts-count: (+ current-posts-count u1) })
    )
    (map-set post-media-views
      { post-id: post-id }
      {
        view-count: u0,
        last-updated: stacks-block-height
      }
    )
    (var-set next-post-id (+ post-id u1))
    (ok post-id)
  )
)

(define-public (increment-media-view (post-id uint))
  (let (
    (post (unwrap! (get-post post-id) ERR_NOT_FOUND))
    (media-views (default-to { view-count: u0, last-updated: u0 } 
                              (get-post-media-views post-id)))
  )
    (asserts! (is-valid-post-id post-id) ERR_INVALID_INPUT)
    (asserts! (get active post) ERR_NOT_FOUND)
    (asserts! (> (get media-type post) MEDIA_TYPE_TEXT) ERR_INVALID_INPUT)
    
    (ok (map-set post-media-views
      { post-id: post-id }
      {
        view-count: (+ (get view-count media-views) u1),
        last-updated: stacks-block-height
      }
    ))
  )
)

(define-public (like-post (post-id uint))
  (let (
    (post (unwrap! (get-post post-id) ERR_NOT_FOUND))
    (already-liked (has-liked-post post-id tx-sender))
  )
    (asserts! (is-valid-post-id post-id) ERR_INVALID_INPUT)
    (asserts! (get active post) ERR_NOT_FOUND)
    (asserts! (not already-liked) ERR_ALREADY_EXISTS)
    (map-set post-likes 
      { post-id: post-id, user: tx-sender }
      { liked: true }
    )
    (map-set posts 
      { post-id: post-id }
      (merge post { likes: (+ (get likes post) u1) })
    )
    (ok true)
  )
)

(define-public (unlike-post (post-id uint))
  (let (
    (post (unwrap! (get-post post-id) ERR_NOT_FOUND))
    (has-liked (has-liked-post post-id tx-sender))
  )
    (asserts! (is-valid-post-id post-id) ERR_INVALID_INPUT)
    (asserts! (get active post) ERR_NOT_FOUND)
    (asserts! has-liked ERR_NOT_FOUND)
    (map-delete post-likes { post-id: post-id, user: tx-sender })
    (map-set posts 
      { post-id: post-id }
      (merge post { likes: (- (get likes post) u1) })
    )
    (ok true)
  )
)

(define-public (follow-user (user-to-follow principal))
  (let (
    (follower-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR_NOT_FOUND))
    (following-profile (unwrap! (map-get? user-profiles { user: user-to-follow }) ERR_NOT_FOUND))
    (already-following (is-following tx-sender user-to-follow))
  )
    (asserts! (not (is-eq tx-sender user-to-follow)) ERR_INVALID_INPUT)
    (asserts! (not already-following) ERR_ALREADY_EXISTS)
    (map-set user-follows 
      { follower: tx-sender, following: user-to-follow }
      { active: true }
    )
    (map-set user-profiles 
      { user: tx-sender }
      (merge follower-profile { following: (+ (get following follower-profile) u1) })
    )
    (map-set user-profiles 
      { user: user-to-follow }
      (merge following-profile { followers: (+ (get followers following-profile) u1) })
    )
    (ok true)
  )
)

(define-public (unfollow-user (user-to-unfollow principal))
  (let (
    (follower-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR_NOT_FOUND))
    (following-profile (unwrap! (map-get? user-profiles { user: user-to-unfollow }) ERR_NOT_FOUND))
    (is-following-user (is-following tx-sender user-to-unfollow))
  )
    (asserts! is-following-user ERR_NOT_FOUND)
    (map-delete user-follows { follower: tx-sender, following: user-to-unfollow })
    (map-set user-profiles 
      { user: tx-sender }
      (merge follower-profile { following: (- (get following follower-profile) u1) })
    )
    (map-set user-profiles 
      { user: user-to-unfollow }
      (merge following-profile { followers: (- (get followers following-profile) u1) })
    )
    (ok true)
  )
)

(define-public (delete-post (post-id uint))
  (let (
    (post (unwrap! (get-post post-id) ERR_NOT_FOUND))
  )
    (asserts! (is-valid-post-id post-id) ERR_INVALID_INPUT)
    (asserts! (is-eq (get author post) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (get active post) ERR_NOT_FOUND)
    (map-set posts 
      { post-id: post-id }
      (merge post { active: false })
    )
    (ok true)
  )
)

(define-public (tip-post (post-id uint) (amount uint))
  (let (
    (post (unwrap! (get-post post-id) ERR_NOT_FOUND))
    (author (get author post))
    (tipper-profile (unwrap! (map-get? user-profiles { user: tx-sender }) ERR_NOT_FOUND))
    (author-profile (unwrap! (map-get? user-profiles { user: author }) ERR_NOT_FOUND))
    (platform-fee-amount (calculate-platform-fee amount))
    (creator-amount (- amount platform-fee-amount))
  )
    (asserts! (is-valid-post-id post-id) ERR_INVALID_INPUT)
    (asserts! (get active post) ERR_NOT_FOUND)
    (asserts! (is-valid-tip-amount amount) ERR_INVALID_INPUT)
    (asserts! (not (is-eq tx-sender author)) ERR_INVALID_INPUT)
    
    ;; Transfer STX from tipper to author
    (try! (stx-transfer? creator-amount tx-sender author))
    
    ;; Transfer platform fee to contract owner
    (if (> platform-fee-amount u0)
      (begin
        (try! (stx-transfer? platform-fee-amount tx-sender CONTRACT_OWNER))
        (var-set total-platform-earnings (+ (var-get total-platform-earnings) platform-fee-amount))
      )
      true
    )
    
    ;; Record the tip
    (map-set post-tips 
      { post-id: post-id, tipper: tx-sender }
      {
        amount: amount,
        timestamp: stacks-block-height
      }
    )
    
    ;; Update post tips received
    (map-set posts 
      { post-id: post-id }
      (merge post { tips-received: (+ (get tips-received post) amount) })
    )
    
    ;; Update tipper profile
    (map-set user-profiles 
      { user: tx-sender }
      (merge tipper-profile { total-tips-sent: (+ (get total-tips-sent tipper-profile) amount) })
    )
    
    ;; Update author profile
    (map-set user-profiles 
      { user: author }
      (merge author-profile { total-tips-received: (+ (get total-tips-received author-profile) creator-amount) })
    )
    
    (ok { tip-amount: amount, creator-received: creator-amount, platform-fee: platform-fee-amount })
  )
)

(define-public (update-platform-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-fee u1000) ERR_INVALID_INPUT) ;; Max 10%
    (var-set platform-fee new-fee)
    (ok true)
  )
)