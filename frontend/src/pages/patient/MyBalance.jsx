import { useEffect, useState } from 'react'
import { api } from '../../api/client'

// The logged-in patient's balance (query Q2 run with their own ID)
export default function MyBalance() {
  const [balance, setBalance] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    api.get('/me/balance')
      .then(setBalance)
      .catch((e) => setError(e.message))
  }, [])

  const money = (n) => `$${Number(n).toFixed(2)}`

  return (
    <div className="panel">
      <h2>My balance</h2>
      {error && <p className="error-message">{error}</p>}
      {!balance && !error && <p>Loading…</p>}
      {balance && (
        <>
          <table className="data-table balance-table">
            <tbody>
              <tr><th>Visits</th><td>{money(balance.visits)}</td></tr>
              <tr><th>Late-cancel fees</th><td>{money(balance.fees)}</td></tr>
              <tr><th>Paid</th><td>{money(balance.paid)}</td></tr>
              <tr className="balance-total">
                <th>{balance.balance < 0 ? 'Credit balance' : 'Balance due'}</th>
                <td>{money(Math.abs(balance.balance))}</td>
            </tr>
            </tbody>
          </table>
          <p className="field-hint">
            {Number(balance.balance) > 0
              ? 'You can pay at the front desk or call the clinic.'
              : 'You are all paid up. Thank you!'}
          </p>
        </>
      )}
    </div>
  )
}
