import { getFirestore, collection, query, where, getDocs } from "firebase/firestore";
import { getAuth, onAuthStateChanged, User } from "firebase/auth";

// Function to check for expiring fridge items
async function checkExpiringItems(userId: string) {
  const db = getFirestore();
  const now = new Date();
  const sevenDaysFromNow = new Date();
  sevenDaysFromNow.setDate(now.getDate() + 7);

  const fridgeRef = collection(db, "fridgeItems");
  const q = query(fridgeRef, where("userId", "==", userId));

  try {
    const querySnapshot = await getDocs(q);
    const expiringItems: { name: string; daysLeft: number }[] = [];

    querySnapshot.forEach((doc) => {
      const item = doc.data();
      const expiryDate = item.expiryDate.toDate(); // Convert Firestore timestamp to Date

      if (expiryDate <= sevenDaysFromNow) {
        const daysLeft = Math.ceil((expiryDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
        expiringItems.push({ name: item.name, daysLeft });
      }
    });

    if (expiringItems.length > 0) {
      notifyUser(expiringItems);
    }
  } catch (error) {
    console.error("Error fetching fridge items:", error);
  }
}

// Function to show local notifications
function notifyUser(expiringItems: { name: string; daysLeft: number }[]) {
  if (!("Notification" in window)) {
    console.log("Browser does not support notifications.");
    return;
  }

  Notification.requestPermission().then((permission) => {
    if (permission === "granted") {
      expiringItems.forEach((item) => {
        new Notification("Expiry Alert", {
          body: `Item "${item.name}" expires in ${item.daysLeft} days.`,
        });
      });
    }
  });
}

// ✅ Get the logged-in user ID dynamically
const auth = getAuth();

onAuthStateChanged(auth, (user: User | null) => {
  if (user) {
    // User is logged in, get their ID and check expiry
    checkExpiringItems(user.uid);
  }
});
