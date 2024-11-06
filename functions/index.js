/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");


const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.sendMessageNotification = onDocumentCreated(
    {
      region: 'asia-northeast1',
      document: "chat_rooms/{chatRoomId}/messages/{messageId}",
    }, async (event) => {
        
  try {
    const messageSnapshot = event.data; // DocumentSnapshot
    const messageData = messageSnapshot.data(); // Get the data

    // Log message data for debugging
    console.log(`Message Data: ${JSON.stringify(messageData)}`);

    const receiverId = messageData.receiverID;
    const senderName = messageData.senderName;
    const messageText = messageData.message;

    // Validate required fields
    if (!receiverId || !senderName || !messageText) {
      console.error('Missing required message fields');
      return;
    }

    const firestore = getFirestore();
    const messaging = getMessaging();

    // Get the receiver's FCM token
    const receiverDoc = await firestore.collection("users").doc(receiverId).get();

    if (!receiverDoc.exists) {
      console.error(`No user found with ID ${receiverId}`);
      return;
    }

    const receiverData = receiverDoc.data();
    const fcmToken = receiverData.fcmToken;

    if (!fcmToken) {
      console.error(`No FCM token for user with ID ${receiverId}`);
      return;
    }

    // Prepare the message payload without 'clickAction'
    const message = {
      notification: {
        title: `New message from ${senderName}`,
        body: messageText,
      },
      token: fcmToken,
    };

    // Send the notification
    const response = await messaging.send(message);
    console.log(`Notification sent successfully: ${response}`);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
