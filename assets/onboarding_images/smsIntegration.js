const axios = require('axios');

// Define the API details
const url = "https://sys.wasms.net/api/get/credits";
const params = {
    secret: "96b4df4a089078f6e83859902c0e3cb5dc6e0b68"
};

// Make the GET request
axios.get(url, { params })
    .then(response => {
        console.log("Success:", response.data);
    })
    .catch(error => {
        if (error.response) {
            console.error("Error:", error.response.status, error.response.data);
        } else {
            console.error("Error:", error.message);
        }
    });