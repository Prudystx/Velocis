;; Velocis - Decentralized Social Media Platform
;; A trustless social interaction platform built on Stacks

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_INPUT (err u400))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant MIN_TIP_AMOUNT u1000000) ;; 1 STX in microSTX

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
    active: bool
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
    created-at: uint
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
        created-at: stacks-block-height
      }
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
        active: true
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