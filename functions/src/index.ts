import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
// // Start writing functions
// // https://firebase.google.com/docs/functions/typescript

admin.initializeApp();

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});
