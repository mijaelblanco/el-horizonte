/* eslint-disable camelcase */
/* eslint-disable max-len */
const functions = require("firebase-functions");
const axios = require("axios");
const admin = require("firebase-admin");
const cors = require("cors")({origin: true});

admin.initializeApp();

exports.checkHorizonte = functions.https.onRequest((req, res) => {
  let i = req.url.split("/");
  i = i[1];
  cors(req, res, () => {
    if (req.method !== "GET") {
      return res.status(401).json({
        message: "Not allowed.",
      });
    }

    const today = new Date();
    const todayMX = today.toLocaleString("es-MX", {timeZone: "America/Monterrey"});
    const [day, month, year] = todayMX.split("/");
    console.log(month + day + year);

    console.log("http://tr.info7.mx/services/app.php?fi=2022-"+month+"-"+day+"&ff=2022-"+month+"-"+day+"&sitio=eh");

    return axios.get("http://tr.info7.mx/services/app.php?fi=2022-"+month+"-"+day+"&ff=2022-"+month+"-"+day+"&sitio=eh")
        .then((response) => {
          const url = response.data[i].url;
          const id = response.data[i].id;
          const category = response.data[i].seccion;
          const fecha_publicacion = response.data[i].fecha_publicacion;
          const timestamp = new Date().toISOString().replace(/[^0-9]/gm, "").substr(0, 14);
          const title = response.data[i].titulo;
          // const sumario = response.data[0].sumario;
          const description = response.data[i].cuerpo;
          // const keywords = response.data[0].keywords;
          const imagenes = response.data[i].imagenes[0];
          let video = response.data[i].videos;

          let type;

          if (video == "") {
            type = "image";
            video = "";
          } else {
            type = "video";
          }
          const userObject = {
            id: id,
            description: description,
            ["image url"]: imagenes,
            title: title,
            source: url,
            views: 0,
            loves: 0,
            ["content type"]: type,
            // ["content type"]: "image",
            timestamp: timestamp,
            category: category,
            date: fecha_publicacion,
            video: video,
          };

          admin.firestore().collection("contents").doc(id).set(userObject);

          return res.status(200).json({
            message: "Executed." + " " + id,
          });
        })
        .catch((err) => {
          return res.status(500).json({
            error: err,
          });
        }).catch(function(error) {
          console.log("ID error.", error);
        });
  });
});
