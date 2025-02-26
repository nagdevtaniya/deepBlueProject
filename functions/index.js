const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Handle Google Form submissions
exports.handleFormSubmission = onRequest(async (req, res) => {
  try {
    const formData = req.body;

    // Validate the request
    if (!formData.eventTitle || !formData.guestCount || !formData.userId) {
      logger.error("Invalid request: Missing eventTitle, guestCount, or userId.");
      return res.status(400).send("Invalid request: Missing eventTitle, guestCount, or userId.");
    }

    // Find the event in Firestore
    const eventsSnapshot = await admin.firestore()
      .collection("users")
      .doc(formData.userId)
      .collection("events")
      .where("eventTitle", "==", formData.eventTitle)
      .get();

    if (eventsSnapshot.empty) {
      logger.error("No matching event found.");
      return res.status(404).send("Event not found.");
    }

    // Update the totalGuests field
    const eventDoc = eventsSnapshot.docs[0];
    const guestCount = parseInt(formData.guestCount, 10);

    if (isNaN(guestCount)) {
      logger.error("Invalid guestCount: Not a number.");
      return res.status(400).send("Invalid guestCount: Not a number.");
    }

    // Log before update
    logger.log("Updating totalGuests for event:", eventDoc.id);
    logger.log("Current totalGuests:", eventDoc.data().totalGuests);
    logger.log("Incrementing by:", guestCount);

    // Update the totalGuests field
    await eventDoc.ref.update({
      totalGuests: admin.firestore.FieldValue.increment(guestCount),
    });

    // Log after update
    const updatedEvent = await eventDoc.ref.get();
    logger.log("Updated totalGuests:", updatedEvent.data().totalGuests);

    logger.log("Guest count updated successfully.");
    return res.status(200).send("Guest count updated.");
  } catch (error) {
    logger.error("Error updating guest count:", error);
    return res.status(500).send("Internal Server Error");
  }
});