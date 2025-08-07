# Velocis

**Decentralized Social Media Platform on Stacks**

Velocis is an experimental platform that reimagines decentralized social interactions by integrating on-chain actions with user experiences. It offers an immutable, trustless environment for sharing and interacting with content, where each post, like, follow, and tip is permanently recorded on the Stacks blockchain.

## 🚀 Key Features

- **Immutable Posts**: All content is stored permanently on-chain
- **Trustless Interactions**: Likes, follows, and user interactions without intermediaries
- **Content Monetization**: Direct STX tipping system for content creators
- **Data Ownership**: Users maintain complete control over their social data
- **Transparency**: All social interactions are publicly verifiable
- **Censorship Resistance**: Decentralized content that cannot be arbitrarily removed
- **Creator Economy**: Built-in monetization with automatic fee distribution

## 🏗️ Architecture

### Smart Contract Features
- **User Profiles**: Create and manage decentralized user profiles with tip tracking
- **Post Management**: Create, like, delete, and tip posts with proper authorization
- **Social Graph**: Follow/unfollow functionality with automatic counter updates
- **Tipping System**: Send STX tips to content creators with platform fee handling
- **Content Validation**: Input validation and error handling for all operations
- **Access Control**: Owner-only functions for platform administration

### Data Structures
- **Posts**: Content with metadata (author, timestamp, likes, tips received, status)
- **User Profiles**: Username, bio, follower/following counts, tip statistics
- **Social Graph**: Follow relationships between users
- **Interactions**: Like/unlike tracking per user per post
- **Tips**: Tip records with amounts and timestamps

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
- Profile creation and management with tip tracking
- Post creation and interaction
- Social graph functionality
- STX tipping with automatic fee distribution
- Proper error handling and validation
- Gas-efficient data structures

### Security Features
- Input validation for all user data and tip amounts
- Authorization checks for sensitive operations
- Prevention of duplicate interactions and self-tipping
- Safe arithmetic operations with overflow protection
- Proper error propagation and STX transfer validation

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Stacks CLI](https://docs.stacks.co/docs/cli) - Command line interface
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

## 🔧 Contract Functions

### Read-Only Functions
- `get-post(post-id)` - Retrieve post by ID with tip information
- `get-user-profile(user)` - Get user profile information including tip statistics
- `has-liked-post(post-id, user)` - Check if user liked a post
- `is-following(follower, following)` - Check follow relationship
- `get-post-tip(post-id, tipper)` - Get tip information for specific post and tipper
- `get-min-tip-amount()` - Get minimum allowed tip amount
- `get-total-platform-earnings()` - Get total platform earnings from fees

### Public Functions
- `create-profile(username, bio)` - Create user profile
- `create-post(content)` - Create new post
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
  active: bool
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
  created-at: uint
}
```

### Tip Record Structure
```clarity
{
  amount: uint,
  timestamp: uint
}
```

## 🧪 Testing

The contract includes comprehensive tests covering:
- Profile creation and validation
- Post creation and interaction
- Social graph operations
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

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🔮 Future Roadmap

- **Content Monetization**: Implement tipping system where users can send STX to content creators ✅ **(Completed)**
- **Advanced Content Types**: Support for images, videos, and rich media through IPFS integration
- **Reputation System**: Token-based reputation scoring for quality content and user trustworthiness
- **Community Governance**: DAO functionality for platform decisions and content moderation policies
- **Cross-Chain Integration**: Enable interactions with other blockchain networks and social platforms
- **Privacy Features**: Zero-knowledge proofs for private messaging and selective content visibility
- **Content Discovery**: AI-powered recommendation engine for personalized feeds and content suggestions
- **Decentralized Identity**: Integration with Stacks identity system for verified profiles and badges
- **Social Token Economy**: Create platform-specific tokens for premium features and community rewards
- **Multi-Language Support**: Internationalization features with decentralized translation services
