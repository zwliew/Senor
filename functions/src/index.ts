import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

export const storeInitialUserData = functions.auth
  .user()
  .onCreate(async (user: admin.auth.UserRecord) => {
    const { email, displayName, uid, photoURL } = user;
    const { creationTime } = user.metadata;

    const collectionRef = admin.firestore().collection("users");
    const snapshot = await collectionRef.where("uid", "==", uid).get();
    if (snapshot.docs.length > 0) return;

    const ref = collectionRef.doc();
    await ref.set({
      uid,
      email,
      displayName,
      photoUrl: photoURL,
      creationTimestamp: new Date(creationTime).getTime(),
      reputation: 10
    });
  });
