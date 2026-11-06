
import { useEffect, useState } from 'react'
import { api } from '../../api/client'
import './Reports.css'

// Admin reports: office revenue, appointment activity, patient health summary, health trends.
const REPORTS = [
    ['revenue', 'Office revenue'],
    ['activity', 'Appointment activity'],
    ['health-summary', 'Patient health summary'],
    ['health-trends', 'Health trends'],
]

const money = (n) =>
    Number(n ?? 0).toLocaleString('en-US', { style: 'currency', currency: 'USD' })

// Adds up one field over all rows
const sum = (rows, field) => rows.reduce((total, r) => total + Number(r[field] ?? 0), 0)

export default function Reports() {
    const [report, setReport] = useState('revenue')
    const [from, setFrom] = useState('')
    const [to, setTo] = useState('')
    const [patientId, setPatientId] = useState('')
    const [patients, setPatients] = useState([])
    const [rows, setRows] = useState([])
    const [trends, setTrends] = useState(null)
    const [hasRun, setHasRun] = useState(false)
    const [loading, setLoading] = useState(false)
    const [error, setError] = useState('')

    useEffect(() => {
        api.get('/lookups/patients')
            .then(setPatients)
            .catch((e) => setError(`Could not load patients: ${e.message}`))
    }, [])

    // Any change to the report or its inputs clears the old result
    function clearResult() {
        setRows([])
        setTrends(null)
        setHasRun(false)
        setError('')
    }

    function pickReport(value) {
        setReport(value)
        clearResult()
    }

    async function runReport() {
        clearResult()

        let url
        if (report === 'health-summary') {
            if (!patientId) {
                setError('Please pick a patient.')
                return
            }
            url = `/reports/health-summary?patientId=${patientId}`
        } else {
            if (!from || !to) {
                setError('Please pick both dates.')
                return
            }
            if (from > to) {
                setError('The From date must be on or before the To date.')
                return
            }
            url = `/reports/${report}?from=${from}&to=${to}`
        }

        setLoading(true)
        try {
            const data = await api.get(url)
            if (report === 'health-trends') {
                setTrends(data)
            } else {
                setRows(data)
            }
            setHasRun(true)
        } catch (e) {
            setError(`Could not run the report: ${e.message}`)
        } finally {
            setLoading(false)
        }
    }

    return (
        <div className="reports-page">
            <h2>Clinic Reports</h2>

            <div className="page-actions report-tabs">
                {REPORTS.map(([value, label]) => (
                    <button
                        key={value}
                        type="button"
