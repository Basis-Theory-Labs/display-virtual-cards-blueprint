# Display Virtual Card with iOS

This example repository demonstrates how one can securely display Card data back to users, using [Basis Theory iOS](https://developers.basistheory.com/docs/sdks/mobile/ios).
For full details on what every part of the code is doing, visit our official [blueprint](https://developers.basistheory.com/docs/blueprints/cards/display-virtual-cards).

## 1. Configuring the Backend

Create a `.env` file in the `backend` folder with the following values (or copy from `.env.example`):

```shell
# Card issuer values. Credential is added as value to 'Authorization' header.
ISSUER_GET_CARD_URL=
ISSUER_CREDENTIAL=

# Card ID for Basis Theory (BT)
BT_CARD_ID=

# Basis Theory API Keys
BT_PUBLIC_API_KEY=
BT_PRIVATE_API_KEY=
BT_MGMT_API_KEY=
```

The Public Application needs to have `token:create` permission.

The Private Application needs to have `token:read` and `token:use` permissions on the `/pci/` container with `reveal` transform.

The Management Application needs to have `proxy: create` permission.

## 2. Running the Backend

To start the [Express.js](https://expressjs.com/) backend, simply run the following command from the `backend` folder:

```shell
yarn start
```

## 3. Configurting the iOS App

Create a `Env.plist` file with the following values (or copy from `.Env.plist.example`):

- `issuerCardId` -> Id for the Card that you want to fetch from the third party issuer.
- `btCardId` -> Id for the Card that you want to fetch from Basis Theory.
- `proxyKey` -> Key obtained from the response of `/create-proxy` from the backend.
- `btPublicKey` -> Your public Basis Theory API Key.

## 4. Running the iOS App

Open the `DisplayIssuedCards` project inside the `ios` folder on Xcode and run it.

Click on `Reveal` from the app to watch the Card values get filled.