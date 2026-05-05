/*import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import { Auth0Provider } from "@auth0/auth0-react";

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
*/

import React from "react";
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App.jsx';
import {ToastContainer} from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import {Provider} from "react-redux";
import { Auth0Provider } from "@auth0/auth0-react";
import { BrowserRouter } from "react-router-dom";

const AUTH0_DOMAIN = "dev-tgh014l8cj73afdo.us.auth0.com";
const AUTH0_CLIENT_ID = "rLV5XaLT1lGdlQFfJCSuWGJLA1NalUBS";

ReactDOM.createRoot(document.getElementById('root')).render(
  <>
    <Auth0Provider
      domain={AUTH0_DOMAIN}
      clientId={AUTH0_CLIENT_ID}
      authorizationParams={{
        redirect_uri: window.location.origin
      }}
    >
        <ToastContainer position="top-center" />
        <App />
    </Auth0Provider>
  </>,
);

