import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as Sentencer from "sentencer";
import * as capitalize from "capitalize";

admin.initializeApp();

export const storeInitialUserData = functions.auth
  .user()
  .onCreate(async (user: admin.auth.UserRecord) => {
    const {
      email,
      uid,
      photoURL,
      metadata: { creationTime }
    } = user;
    let { displayName } = user;

    const collectionRef = admin.firestore().collection("users");
    const snapshot = await collectionRef.where("uid", "==", uid).get();
    if (snapshot.docs.length > 0) return;

    const creationTimestamp = new Date(creationTime).getTime();

    if (!displayName) {
      if (email) {
        displayName = email.substring(0, email.indexOf("@"));
      } else {
        displayName = capitalize.words(
          Sentencer.make("{{ adjective }} {{ adjective }} {{ noun }}")
        );
      }
    }

    const data: any = {
      uid,
      email,
      displayName,
      creationTimestamp,
      reputation: 10
    };

    if (photoURL) data.photoUrl = photoURL;

    const ref = collectionRef.doc();
    await ref.set(data);
  });
