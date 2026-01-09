# Bible API Setup Instructions

## Getting Your Free API Key

The Bible reading feature uses the [API.Bible](https://scripture.api.bible/) service, which provides free access to Bible content.

### Steps to Get Your API Key:

1. **Visit** https://scripture.api.bible/
2. **Sign up** for a free account
3. **Create an API key** in your dashboard
4. **Copy your API key**

### How to Configure Your API Key

You have **three options** to set your API key:

#### Option 1: Direct Code Update (Simplest)
1. Open `The Alter beta 2/Managers/BibleAPIManager.swift`
2. Find the line with `return "RtnmWQigc0YeauuMRryDF"` (around line 30)
3. Replace `"RtnmWQigc0YeauuMRryDF"` with your API key:
   ```swift
   return "YOUR_API_KEY_HERE"
   ```

#### Option 2: Environment Variable (For Development)
Set the environment variable before running:
```bash
export BIBLE_API_KEY="your-api-key-here"
```

#### Option 3: Info.plist (For Production)
1. In Xcode, select your project target
2. Go to the "Info" tab
3. Add a new key: `BibleAPIKey` (type: String)
4. Set the value to your API key

### Testing Your API Key

After configuring your API key:
1. Build and run the app
2. Navigate to the "Read" tab
3. Select a book from the Bible
4. If configured correctly, you should see the chapter content

### Troubleshooting

**Error: "Invalid API key"**
- Double-check that your API key is copied correctly (no extra spaces)
- Make sure you're using the key from your API.Bible dashboard
- Wait a few minutes if you just created the key (it may take time to activate)

**Error: "Network error"**
- Check your internet connection
- Verify that API.Bible service is available

### API Limits

The free tier of API.Bible includes:
- Generous rate limits for personal use
- Access to multiple Bible translations
- No credit card required

For more information, visit: https://scripture.api.bible/docs

