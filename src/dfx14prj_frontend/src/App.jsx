import React from "react"
import logo from "./assets/dfinity.svg"

import { createClient } from "@connect2ic/core"
import { defaultProviders } from "@connect2ic/core/providers"
import { Connect2ICProvider } from "@connect2ic/react"

import { AstroX } from "@connect2ic/core/providers/astrox"
import { EarthWallet } from "@connect2ic/core/providers/earth-wallet"
import { InfinityWallet } from "@connect2ic/core/providers/infinity-wallet"
import { InternetIdentity } from "@connect2ic/core/providers/internet-identity"
import { NFID } from "@connect2ic/core/providers/nfid"
import { PlugWallet } from "@connect2ic/core/providers/plug-wallet"
import { StoicWallet } from "@connect2ic/core/providers/stoic-wallet"
/*
 * Connect2ic provides essential utilities for IC app development
 */

import Graffiti from "./Graffiti"
/*
 * Import canister definitions like this:
 */

import * as dfx14prj_backend from "../../declarations/dfx14prj_backend";

/*
 * Some examples to get you started
 */

function App() {
  return (
    <Graffiti />
  )
}

const client = createClient({
  canisters: {
    dfx14prj_backend
  },
  providers: [
    new AstroX(),
    new EarthWallet(),
    new InfinityWallet(),
    new InternetIdentity(),
    new NFID(),
    new PlugWallet(),
    new StoicWallet(),
  ],
  globalProviderConfig: {
    dev: false,
    autoConnect: true,
    appName: "Life Vibes",
  },
})

export default () => (
  <Connect2ICProvider client={client}
    canisters={dfx14prj_backend}
  >
    <App />
  </Connect2ICProvider>
)
