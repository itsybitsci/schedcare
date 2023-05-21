import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as express from "express";
import * as cors from "cors";
var serviceAccount = require("../serviceAccountKey.json"); // eslint-disable-line

admin.initializeApp(
  {
    credential: admin.credential.cert(serviceAccount),
  }
);

const app = express();
const db = admin.firestore();
const auth = admin.auth();
app.use(cors({origin: true}));
const key = "XL(CIO^AgFY^8O*6pIWb#sMTHHi063!t-YbiD#H2ra#@Z6uP#prnCT(km-M7rXa16B90n1Ct0wydCt#M18Mpe-VClbf3uliEW8IV";

app.delete("/api/delete-user/:id", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      await auth.deleteUser(req.params.id);

      return res.status(200).send({status: "success"});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-user/:id", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const user = await db.collection("users").doc(req.params.id).get();
      const response = user.data();

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-consultationRequest/:id", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const consultationRequest = await db.collection("consultation_requests").doc(req.params.id).get();
      const response = consultationRequest.data();

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-notification/:id", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const consultationRequest = await db.collection("notifications").doc(req.params.id).get();
      const response = consultationRequest.data();

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-userTokenList/:id", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const consultationRequest = await db.collection("user_tokens").doc(req.params.id).get();
      const response = consultationRequest.data();

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-all-users", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const query = db.collection("users");

      // eslint-disable-next-line @typescript-eslint/ban-types
      const response: {}[] = [];

      await query.get().then((querySnapshot) => {
        const docs = querySnapshot.docs;

        for (const doc of docs) {
          const selectedItem = doc.data().role === "patient" ? {
            id: doc.data().id,
            email: doc.data().email,
            role: doc.data().role,
            firstName: doc.data().firstName,
            lastName: doc.data().lastName,
            suffix: doc.data().suffix,
            age: doc.data().age,
            birthDate: doc.data().birthDate,
            sex: doc.data().sex,
            phoneNumber: doc.data().phoneNumber,
            address: doc.data().address,
            civilStatus: doc.data().civilStatus,
            classification: doc.data().classification,
            uhsIdNumber: doc.data().uhsIdNumber,
            vaccinationStatus: doc.data().vaccinationStatus,
            isApproved: doc.data().isApproved,
            lastLogin: doc.data().lastLogin,
            modifiedAt: doc.data().modifiedAt,
            createdAt: doc.data().createdAt,
          } : {
            id: doc.id,
            email: doc.data().email,
            role: doc.data().role,
            prefix: doc.data().prefix,
            firstName: doc.data().firstName,
            lastName: doc.data().lastName,
            suffix: doc.data().suffix,
            sex: doc.data().sex,
            specialization: doc.data().specialization,
            isApproved: doc.data().isApproved,
            lastLogin: doc.data().lastLogin,
            modifiedAt: doc.data().modifiedAt,
            createdAt: doc.data().createdAt,
          };
          response.push(selectedItem);
        }
      });

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-all-consultationRequests", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const query = db.collection("consultation_requests");

      // eslint-disable-next-line @typescript-eslint/ban-types
      const response: {}[] = [];

      await query.get().then((querySnapshot) => {
        const docs = querySnapshot.docs;

        for (const doc of docs) {
          const selectedItem = {
            id: doc.data().id,
            patientId: doc.data().patientId,
            doctorId: doc.data().doctorId,
            consultationRequestPatientTitle: doc.data().consultationRequestPatientTitle,
            consultationRequestDoctorTitle: doc.data().consultationRequestDoctorTitle,
            consultationRequestBody: doc.data().consultationRequestBody,
            status: doc.data().status,
            consultationType: doc.data().consultationType,
            consultationDateTime: doc.data().consultationDateTime,
            modifiedAt: doc.data().modifiedAt,
            createdAt: doc.data().createdAt,
            messages: doc.data().messages,
            meetingId: doc.data().meetingId,
            patientAttachmentUrl: doc.data().patientAttachmentUrl,
            doctorAttachmentUrl: doc.data().doctorAttachmentUrl,
            isPatientSoftDeleted: doc.data().isPatientSoftDeleted,
            isDoctorSoftDeleted: doc.data().isDoctorSoftDeleted,
          };
          response.push(selectedItem);
        }
      });

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-all-notifications", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const query = db.collection("notifications");

      // eslint-disable-next-line @typescript-eslint/ban-types
      const response: {}[] = [];

      await query.get().then((querySnapshot) => {
        const docs = querySnapshot.docs;

        for (const doc of docs) {
          const selectedItem = {
            id: doc.data().id,
            patientId: doc.data().patientId,
            doctorId: doc.data().doctorId,
            title: doc.data().title,
            body: doc.data().body,
            sentAt: doc.data().sentAt,
            sender: doc.data().sender,
            isRead: doc.data().isRead,
          };
          response.push(selectedItem);
        }
      });

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

app.get("/api/get-all-userTokenLists", (req, res) => {
  (async () => {
    try {
      const bearerToken = req.get("Authorization")!.split("Bearer ")[1]; // eslint-disable-line

      if (bearerToken !== key) {
        return res.status(401).send({status: "failed", message: "Unauthorized"});
      }

      const query = db.collection("user_tokens");

      // eslint-disable-next-line @typescript-eslint/ban-types
      const response: {}[] = [];

      await query.get().then((querySnapshot) => {
        const docs = querySnapshot.docs;

        for (const doc of docs) {
          const selectedItem = {
            deviceTokens: doc.data().deviceTokens,
            modifiedAt: doc.data().modifiedAt,
            createdAt: doc.data().createdAt,
          };
          response.push(selectedItem);
        }
      });

      return res.status(200).send({status: "success", data: response});
    } catch (e) {
      return res.status(401).send({status: "failed", message: "Unauthorized"});
    }
  })();
});

exports.app = functions.https.onRequest(app);
