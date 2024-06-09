const functions = require("firebase-functions");
const admin = require("firebase-admin");

//var serviceAccount = require("./auth/edupost-firebase-firebase-adminsdk-bnvva-ca80dfd548.json");

admin.initializeApp({

});


exports.myFunction = functions.firestore
    .document("turmas/{idDocumento}/mensagens/{idMensagem}")
    .onCreate(async (snapshot, context) => {
        const turmaRef = admin.firestore().collection("turmas").doc(context.params.idDocumento);
        const turmaSnapshot = await turmaRef.get();

        //const nome = turmaSnapshot.data()["curso"];
        //const semestre = turmaSnapshot.data()["semestre"];
        const conteudo = snapshot.data()["conteudo"];

        return admin.messaging().send(
            {
                notification: {
                    title: snapshot.data()["remetente"],
                    body: conteudo
                },
                topic: context.params.idDocumento
            }
        );
    });
