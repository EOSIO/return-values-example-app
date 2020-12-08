// To see this in action, run this in a terminal:
//      gp preview $(gp url 8000)

import React, { useState, useEffect } from 'react'
import * as ReactDOM from 'react-dom'
import { Api, JsonRpc } from 'eosjs'
import { JsSignatureProvider } from 'eosjs/dist/eosjs-jssig'

import './styles.css'

import SumAction from './SumAction'

const rpc = new JsonRpc('') // nodeos and web server are on same port
const privateKey = '5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3'

const App: React.FC = () => {
  const [api, setApi] = useState<Api>()

  useEffect(() => {
    setApi(new Api({ rpc, signatureProvider: new JsSignatureProvider([privateKey]) }))
  }, [])

  return (
    <div className='container'>
      <div className='header'>Return Values Example App</div>
      <SumAction api={api}/>
    </div>
  )
}

ReactDOM.render(
  <App />,
  document.getElementById('example')
)
