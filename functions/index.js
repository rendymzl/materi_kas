const { onCall } = require("firebase-functions/v2/https");

exports.tes = onCall((request) => {
  return request.auth;
});
