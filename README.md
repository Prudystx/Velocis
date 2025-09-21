# Velocis

**Decentralized Social Media Platform on Stacks with IPFS Media Support**

Velocis is an experimental platform that reimagines decentralized social interactions by integrating on-chain actions with user experiences. It offers an immutable, trustless environment for sharing and interacting with rich media content, where each post, like, follow, and tip is permanently recorded on the Stacks blockchain, with media assets stored on IPFS.

## 🚀 Key Features

- **Immutable Posts**: All content is stored permanently on-chain with IPFS media references
- **Rich Media Support**: Images, videos, audio, and documents through IPFS integration
- **Trustless Interactions**: Likes, follows, and user interactions without intermediaries
- **Content Monetization**: Direct STX tipping system for content creators
- **Data Ownership**: Users maintain complete control over their social data and media
- **Transparency**: All social interactions are publicly verifiable
- **Censorship Resistance**: Decentralized content that cannot be arbitrarily removed
- **Creator Economy**: Built-in monetization with automatic fee distribution
- **Media Analytics**: View tracking for rich media content

## 🎨 Media Types Supported

- **Text Posts**: Traditional text-based social media posts (280 characters)
- **Images**: Photos, artwork, memes, and visual content via IPFS
- **Videos**: Short clips, tutorials, entertainment content via IPFS
- **Audio**: Music, podcasts, voice messages via IPFS
- **Documents**: PDFs, presentations, and other file formats via IPFS

## 🏗️ Architecture

### Smart Contract Features
- **User Profiles**: Create and manage decentralized user profiles with avatar support
- **Rich Media Posts**: Create posts with IPFS-linked media content
- **Post Management**: Create, like, delete, and tip posts with proper authorization
- **Social Graph**: Follow/unfollow functionality with automatic counter updates
- **Tipping System**: Send STX tips to content creators with platform fee handling
- **Media Analytics**: Track views and engagement for rich media content
- **Content Validation**: Input validation and error handling for all operations
- **Access Control**: Owner-only functions for platform administration

### Data Structures
- **Posts**: Content with metadata (author, timestamp, likes, tips received, media type, IPFS hash)
- **User Profiles**: Username, bio, follower/following counts, tip statistics, avatar IPFS hash
- **Social Graph**: Follow relationships between users
- **Interactions**: Like/unlike tracking per user per post
- **Tips**: Tip records with amounts and timestamps
- **Media Views**: View count tracking for rich media content

### IPFS Integration
- **Decentralized Storage**: Media files stored on IPFS for censorship resistance
- **Content Addressing**: Immutable IPFS hashes ensure content integrity
- **Metadata Storage**: Rich media metadata stored on-chain for discoverability
- **Bandwidth Optimization**: Only IPFS hashes stored on-chain, reducing costs
- **Global Accessibility**: Content accessible through any IPFS gateway

## 💰 Monetization Features

### Tipping System
- **Direct Creator Support**: Send STX directly to content creators
- **Minimum Tip Amount**: 1 STX minimum to ensure meaningful contributions
- **Platform Fee**: Configurable platform fee (default 1%) for sustainability
- **Tip Tracking**: Complete transparency of all tip transactions
- **Creator Analytics**: Track total tips received and sent per user

### Fee Structure
- Platform fee: 1% of tip amount (configurable by contract owner)
- Minimum tip: 1,000,000 microSTX (1 STX)
- Fees automatically distributed to platform and creator

## 🛠️ Technical Implementation

### Clarity Smart Contract
The core contract (`velocis.clar`) implements:
- Profile creation and management with avatar support
- Rich media post creation with IPFS integration
- Post interaction and media view tracking
- Social graph functionality
- STX tipping with automatic fee distribution
- Proper error handling and validation
- Gas-efficient data structures

### Security Features
- Input validation for all user data, IPFS hashes, and tip amounts
- Authorization checks for sensitive operations
- Prevention of duplicate interactions and self-tipping
- Safe arithmetic operations with overflow protection
- Proper error propagation and STX transfer validation
- Media type validation and content integrity checks

### IPFS Features
- **Hash Validation**: Ensures IPFS hashes are properly formatted
- **Media Type Constants**: Predefined constants for different media types
- **Metadata Support**: Optional metadata for rich media descriptions
- **View Tracking**: Analytics for media engagement
- **Avatar Support**: IPFS-based profile avatars

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Stacks CLI](https://docs.stacks.co/docs/cli) - Command line interface
- [IPFS Node](https://ipfs.io/) or [Pinata](https://pinata.cloud/) for media storage
- Node.js and npm (for frontend development)
- STX for testing tipping functionality

## 🚀 Getting Started

### Clone the Repository
```bash
git clone https://github.com/yourusername/velocis.git
cd velocis
```

### Install Dependencies
```bash
clarinet install
```

### Run Tests
```bash
clarinet test
```

### Check Contract
```bash
clarinet check
```

### Deploy Locally
```bash
clarinet integrate
```

### IPFS Setup
1. Install IPFS or set up Pinata account
2. Upload media files to IPFS
3. Use returned IPFS hash in media post creation

## 🔧 Contract Functions

### Read-Only Functions
- `get-post(post-id)` - Retrieve post by ID with media information
- `get-user-profile(user)` - Get user profile information including avatar
- `has-liked-post(post-id, user)` - Check if user liked a post
- `is-following(follower, following)` - Check follow relationship
- `get-post-tip(post-id, tipper)` - Get tip information for specific post and tipper
- `get-min-tip-amount()` - Get minimum allowed tip amount
- `get-total-platform-earnings()` - Get total platform earnings from fees
- `get-post-media-views(post-id)` - Get media view count for a post
- `get-media-type-constants()` - Get available media type constants

### Public Functions
- `create-profile(username, bio)` - Create user profile
- `update-profile-avatar(avatar-ipfs-hash)` - Set profile avatar via IPFS
- `create-post(content)` - Create text-only post
- `create-media-post(content, media-type, ipfs-hash, metadata)` - Create rich media post
- `increment-media-view(post-id)` - Track media view for analytics
- `like-post(post-id)` - Like a post
- `unlike-post(post-id)` - Unlike a post
- `follow-user(user)` - Follow another user
- `unfollow-user(user)` - Unfollow a user
- `delete-post(post-id)` - Delete own post
- `tip-post(post-id, amount)` - Send STX tip to post creator
- `update-platform-fee(new-fee)` - Update platform fee (owner only)

## 📊 Data Models

### Post Structure
```clarity
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
```

### User Profile Structure
```clarity
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
```

### Media View Structure
```clarity
{
  view-count: uint,
  last-updated: uint
}
```

### Media Types
- `0` - Text only
- `1` - Image
- `2` - Video
- `3` - Audio
- `4` - Document

## 🧪 Testing

The contract includes comprehensive tests covering:
- Profile creation and avatar management
- Text and media post creation
- IPFS hash validation
- Media view tracking
- Post interaction and social graph operations
- STX tipping functionality
- Platform fee calculations
- Error handling scenarios
- Edge cases and security checks

## 🔒 Security Considerations

- **Self-Tipping Prevention**: Users cannot tip their own posts
- **Minimum Tip Validation**: Enforced minimum tip amount prevents spam
- **STX Transfer Validation**: All transfers are validated before execution
- **Authorization Checks**: Proper ownership verification for all operations
- **Overflow Protection**: Safe arithmetic operations throughout
- **IPFS Hash Validation**: Ensures proper IPFS hash format and length
- **Media Type Validation**: Prevents invalid media type assignments

## 📱 Frontend Integration Examples

### Creating a Media Post
```javascript
// Upload to IPFS first
const ipfsHash = await uploadToIPFS(mediaFile);

// Create media post on Stacks
const postData = {
  content: "Check out this amazing photo!",
  mediaType: 1, // Image
  ipfsHash: ipfsHash,
  metadata: JSON.stringify({
    filename: "sunset.jpg",
    filesize: "2.1MB",
    dimensions: "1920x1080"
  })
};

await createMediaPost(postData);
```

### Displaying Media Content
```javascript
// Retrieve post data
const post = await getPost(postId);

// Construct IPFS URL
const mediaUrl = `https://ipfs.io/ipfs/${post.ipfs_hash}`;

// Display based on media type
if (post.media_type === 1) {
  // Display image
} else if (post.media_type === 2) {
  // Display video player
}
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🔮 Future Roadmap

- **Advanced Content Types**: Support for images, videos, and rich media through IPFS integration ✅ **(Completed)**
- **Content Moderation Tools**: Community-driven content reporting and moderation system
- **NFT Integration**: Convert popular posts into NFTs with creator royalties
- **Reputation System**: Token-based reputation scoring for quality content and user trustworthiness
- **Community Governance**: DAO functionality for platform decisions and content moderation policies
- **Cross-Chain Integration**: Enable interactions with other blockchain networks and social platforms
- **Privacy Features**: Zero-knowledge proofs for private messaging and selective content visibility
- **Content Discovery**: AI-powered recommendation engine for personalized feeds and content suggestions
- **Decentralized Identity**: Integration with Stacks identity system for verified profiles and badges
- **Social Token Economy**: Create platform-specific tokens for premium features and community rewards
- **Multi-Language Support**: Internationalization features with decentralized translation services
- **Live Streaming**: Real-time video streaming integration with IPFS
- **Content Monetization**: Subscription-based content access and premium creator features
