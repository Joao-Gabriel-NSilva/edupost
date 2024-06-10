const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp({

});


exports.myFunction = functions.firestore
    .document("turmas/{idDocumento}/mensagens/{idMensagem}")
    .onCreate(async (snapshot, context) => {
        const turmaRef = admin.firestore().collection("turmas").doc(context.params.idDocumento);
        const turmaSnapshot = await turmaRef.get();

        const nome = turmaSnapshot.get("curso");
        const semestre = turmaSnapshot.get("semestre");
        const conteudo = snapshot.data()["conteudo"];

        return admin.messaging().send(
            {
                notification: {
                    title: `${nome} ${semestre}°`,
                    body: `${snapshot.data()["remetente"]}: ${conteudo}`
                },
                topic: context.params.idDocumento,
                data: {
                    turma: context.params.idDocumento
                }
            }
        );
    });
