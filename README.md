# FirestoreLargeWriteTest
Test large number of writes in Firestore

This project reproduces a bug in firestore when writing a large amount of data:
- Write many documents consecutively.
- Once the total amount of data exceeds 10MB, the writes to the server will start to fail. The data never makes it to the server, and the completion handler in the client is never called.
- The problem happens regardless of the size of the individual documents.
- The problem happens regardless any time delays in between the writes.
- The problem happens regardless of whether the writes are batched or not.

This is likely the same bug as [this github issue](https://github.com/firebase/firebase-ios-sdk/issues/933#issuecomment-376205394), which the Firebase team is aware of.

## Getting Started
To use the app, you must set up a Firestore database and download the `GoogleService-Info.plist`, replacing that file in this project with the one you download.

## Using the App
The app provides a number of parameters you can change in order to try different things:
- Document size
- Total documents to add
- Number of documents in each batch (for when running in batch mode)
- Delay between writes

Tap the button **Add Docs** to add the documents consecutively without using batch.

Tap the button **Add Docs Batch** to add batches of documents consecutively.

The log area at the bottom will show the progress of the writes, and the results of the completion handler.
