-- Constants
local PDS_HOST = "https://bsky.app"
local CREATE_SESSION_URL = PDS_HOST .. "/xrpc/com.atproto.server.createSession"
local CREATE_POST_URL = PDS_HOST .. "/xrpc/com.atproto.repo.createRecord"

-- Helper function to get current UTC time in ISO format
local function getISOTime()
    return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

-- Prompt for user input while hiding password
print("Enter your Bluesky username:")
local username = read()
print("Enter your app password:")
local password = read("*") -- "*" hides the input

-- Create session
print("Creating session...")
local sessionResponse = http.post(
    CREATE_SESSION_URL,
    textutils.serialiseJSON({
        identifier = username,
        password = password
    }),
    {
        ["Content-Type"] = "application/json"
    }
)

if not sessionResponse then
    error("Failed to connect to Bluesky")
end

local sessionData = textutils.unserialiseJSON(sessionResponse.readAll())
sessionResponse.close()

if not sessionData or not sessionData.accessJwt then
    error("Failed to create session. Check your credentials.")
end

print("Session created successfully!")

-- Prompt for post content
print("Enter your post text:")
local postText = read()

-- Create post
print("Creating post...")
local postResponse = http.post(
    CREATE_POST_URL,
    textutils.serialiseJSON({
        repo = username,
        collection = "app.bsky.feed.post",
        record = {
            text = postText,
            createdAt = getISOTime()
        }
    }),
    {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. sessionData.accessJwt
    }
)

if not postResponse then
    error("Failed to connect to Bluesky while posting")
end

local postData = textutils.unserialiseJSON(postResponse.readAll())
postResponse.close()

if postData then
    print("Post created successfully!")
else
    print("Failed to create post. Something went wrong.")
end