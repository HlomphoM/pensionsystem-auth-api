/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onCall} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

exports.processPayments = onCall(async (request) => {
  const paymentsRef = db.collection("payments").doc("current");

  try {
    return await db.runTransaction(async (transaction) => {
      const paymentDoc = await transaction.get(paymentsRef);
      if (!paymentDoc.exists) {
        throw new Error("No payment document found");
      }

      const availableBalance = paymentDoc.data().availableBalance || 0;

      const pensionersSnapshot = await db.collection("pensioners")
          .where("status", "==", "Active")
          .get();

      const pensioners = pensionersSnapshot.docs;
      const paymentAmount = 500;
      const totalRequired = pensioners.length * paymentAmount;

      if (availableBalance < totalRequired) {
        throw new Error("Insufficient funds");
      }

      const recipients = pensioners.map((doc) => ({
        pensionerNames: doc.data().pensionerNames,
        amount: paymentAmount,
        timestamp: new Date(),
      }));

      const paymentHistoryRef = paymentsRef.collection("paymentHistory").doc();
      transaction.set(paymentHistoryRef, {
        totalAmount: totalRequired,
        recipients: recipients,
        timestamp: new Date(),
      });

      transaction.update(paymentsRef, {
        availableBalance: availableBalance - totalRequired,
      });

      for (const pensioner of pensioners) {
        const currentBalance = pensioner.data().balance || 0;
        transaction.update(pensioner.ref, {
          balance: currentBalance + paymentAmount,
        });
      }

      return {
        success: true,
        message: "Payments processed successfully",
        recipientCount: pensioners.length,
        totalPaid: totalRequired,
      };
    });
  } catch (error) {
    console.error("Payment processing error:", error);
    throw new Error(error.message);
  }
});
