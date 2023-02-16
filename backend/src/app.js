import * as dotenv from "dotenv";
import express from "express";
import bodyParser from "body-parser";
import { BasisTheory } from "@basis-theory/basis-theory-js";

dotenv.config();

const app = express();
const port = process.env.BACKEND_PORT;

app.use(bodyParser.json());

let bt = await new BasisTheory().init();

app.post("/create-proxy", async (request, response) => {
  const proxy = await bt.proxies.create(
    {
      name: "Reveal Cards Proxy",
      destinationUrl: process.env.ISSUER_GET_CARD_URL,
      requestTransform: {
        code: `module.exports = async function (req) {
          let { args: { body, headers }, bt } = req;

          return {
              body,
              headers: {
                ...headers,
                "Authorization": "${process.env.ISSUER_CREDENTIAL}"
              },
          }
        };`,
      },
      requireAuth: true,
    },
    { apiKey: process.env.BT_MGMT_API_KEY } // management application
  );

  response.send(proxy);
});

app.post("/authorize", async (request, response) => {
  const { nonce } = request.body;

  // authorizing a session returns an empty 200 response
  await bt.sessions.authorize(
    {
      nonce: nonce,
      rules: [
        {
          description: "Reveal only our Card Token",
          priority: 1,
          conditions: [
            {
              attribute: "id",
              operator: "equals",
              value: process.env.BT_CARD_ID, // card token id
            },
          ],
          permissions: ["token:read", "token:use"],
          transform: "reveal",
        },
      ],
    },
    { apiKey: process.env.BT_PRIVATE_API_KEY } // private application
  );

  // this response is arbitrary and not required
  response.json({
    result: "success",
  });
});

app.listen(port, () => {
  console.log(`Backend app listening on port ${port}`);
});
