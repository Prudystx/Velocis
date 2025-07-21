# Velocis

**Decentralized Social Media Platform on Stacks**

Velocis is an experimental platform that reimagines decentralized social interactions by integrating on-chain actions with user experiences. It offers an immutable, trustless environment for sharing and interacting with content, where each post, like, and follow is permanently recorded on the Stacks blockchain.

## 🚀 Key Features

- **Immutable Posts**: All content is stored permanently on-chain
- **Trustless Interactions**: Likes, follows, and user interactions without intermediaries
- **Data Ownership**: Users maintain complete control over their social data
- **Transparency**: All social interactions are publicly verifiable
- **Censorship Resistance**: Decentralized content that cannot be arbitrarily removed

## 🏗️ Architecture

### Smart Contract Features
- **User Profiles**: Create and manage decentralized user profiles
- **Post Management**: Create, like, and delete posts with proper authorization
- **Social Graph**: Follow/unfollow functionality with automatic counter updates
- **Content Validation**: Input validation and error handling for all operations
- **Access Control**: Owner-only functions for platform administration

### Data Structures
- **Posts**: Content with metadata (author, timestamp, likes, status)
- **User Profiles**: Username, bio, follower/following counts
- **Social Graph**: Follow relationships between users
- **Interactions**: Like/unlike tracking per user per post

## 🛠️ Technical Implementation

### Clarity Smart Contract
The core contract (`velocis.clar`) implements:
- Profile creation and management
- Post creation and interaction
- Social graph functionality
- Proper error handling and validation
- Gas-efficient data structures

### Security Features
- Input validation for all user data
- Authorization checks for sensitive operations
- Prevention of duplicate interactions
- Safe arithmetic operations
- Proper error propagation

## 📋 Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Stacks CLI](https://docs.stacks.co/docs/cli) - Command line interface
- Node.js and npm (for frontend development)

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
- `get-post(post-id)` - Retrieve post by ID
- `get-user-profile(user)` - Get user profile information
- `has-liked-post(post-id, user)` - Check if user liked a post
- `is-following(follower, following)` - Check follow relationship

### Public Functions
- `create-profile(username, bio)` - Create user profile
- `create-post(content)` - Create new post
- `like-post(post-id)` - Like a post
- `unlike-post(post-id)` - Unlike a post
- `follow-user(user)` - Follow another user
- `unfollow-user(user)` - Unfollow a user
- `delete-post(post-id)` - Delete own post

## 📊 Data Models

### Post Structure
```clarity
{
  author: principal,
  content: (string-ascii 280),
  timestamp: uint,
  likes: uint,
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
  created-at: uint
}
```

## 🧪 Testing

The contract includes comprehensive tests covering:
- Profile creation and validation
- Post creation and interaction
- Social graph operations
- Error handling scenarios
- Edge cases and security checks

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🔮 Future Roadmap

- Frontend web application
- Mobile app development
- Advanced content filtering
- Decentralized identity integration
- Token-based incentive systems
- Cross-chain functionality

