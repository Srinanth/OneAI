// Manages the global user state using Riverpod,
// including loading the User ID and API Keys from storage on startup
// and exposing methods for the Settings screen to update and save these credentials

// it can be used without login and with it, ill decide later. If no User ID is found on startup,
// it generates a UUID and saves it (simulating a "Guest" login).