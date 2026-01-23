// The core logic for the Chat Screen;
// it holds the state of the current open conversation (list of messages + current artifact)

//  When sending a message, it optimistically updates the UI, calls the API, and manages the 'isTyping' state.
// It keeps the Artifact in memory but doesn't expose it to the View.