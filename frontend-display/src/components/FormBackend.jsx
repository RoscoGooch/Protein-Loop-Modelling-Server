import { useState } from "react";
import axios from "axios";
import {toast} from "react-toastify";
import {useNavigate } from "react-router-dom";


function FormBackend() {
    const [step, setStep] = useState(1);
    const [formData, setFormData] = useState({});

    const startGetAngles = (data) => {
        setFormData((prev) => ({ ...prev, ...data }));
        setStep(2);
    };

    const startChooseTargetAngles = (data) => {
        setFormData((prev) => ({ ...prev, ...data }));
        setStep(3);
    };

    return (
        <>
            {step === 1 && <GetChain onSubmit={startGetAngles} />}
            {step === 2 && <GetAngles data={formData} onSubmit={startChooseTargetAngles}/>}
            {step === 3 && <ChooseTargetAngles data={formData} onSubmit={(data) => console.log(data)}/>}
        </>
    );
}

const GetChain = ({ onSubmit }) => {
    const UPDATE_URL = "http://127.0.0.1:5000/setup-data";

    const navigate = useNavigate();

    const handleSubmit = (e) => {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const entries = Object.fromEntries(data);
    axios
        .post(UPDATE_URL, entries)
        .then((response) => {
            console.log(response.data);
            onSubmit({
                ...entries,
                ...response.data
            });
        })
        .catch((error) => {
            console.log(error);
            return toast.error(error.message);
        });  
    }

    return <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
        <div className="formItem">
            <label className="form-label">
                <p>PDBCode of start file:</p>
                <input id="pdbcode" name="pdbcode" type="string" required></input>
            </label>
        </div>
        <button>Submit start file</button>
    </form>
}

const GetAngles = ({ data, onSubmit }) => {
    const UPDATE_URL = "http://127.0.0.1:5000/retrieve-angles";
    const navigate = useNavigate();

    const [startChain, setStartChain] = useState("");

    const handleSubmit = (e) => {
        e.preventDefault(); 
        const formData = new FormData(e.currentTarget);
        const entries = Object.fromEntries(formData); 

        const combinedData = {
            ...data,
            ...entries,
        };

        axios
            .post(UPDATE_URL, entries)
            .then((response) => {
                console.log(response.data);
                onSubmit({
                    ...combinedData,
                    ...response.data,
                });
            })
            .catch((error) => {
                console.log(error);
                return toast.error(error.message);
            });  
    }

    return <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
        <div className="formItem">
        <label className="form-label">
            <p>Select chain: </p>
            <select onChange={(e) => setStartChain(e.target.value)} value={startChain} id="start_chain" name="start_chain" required>
                {data?.chains?.map((chain) => (
                <option key={chain} value={chain}>
                    {chain}
                </option>
                ))}
            </select>
            <p>PDBCode of target file:</p>
            <input id="pdbcode_end" name="pdbcode_end" type="string" required></input>
            <p>Segment beginning:</p>
            <input id="segbeg" name="segbeg" type="int" required></input>
            <p>Segment end:</p>
            <input id="segend" name="segend" type="int" required></input>     
        </label>
        </div>
        <button>Submit details</button>
    </form>
}

const ChooseTargetAngles = ({ data, onSubmit }) => {
    const UPDATE_URL = "http://127.0.0.1:5000/align-angles";
    const segbeg = Number(data.segbeg);
    const segend = Number(data.segend);

    const values = Array.from({ length: segend - segbeg - 1}, (_, i) => (segbeg + 1 + i));

    const [phiAngleSettings, setPhiAngles] = useState(
        Object.fromEntries(values.map((num) => [num, "default"])),
    );

    const [psiAngleSettings, setPsiAngles] = useState(
        Object.fromEntries(values.map((num) => [num, "default"])),
    );

    const handlePhiChange = (num, value) => {
        setPhiAngles((prev) => ({
            ...prev,
            [num]: value
        }));
    };

    const handlePsiChange = (num, value) => {
        setPsiAngles((prev) => ({
            ...prev,
            [num]: value
        }));
    };

    const navigate = useNavigate();

    const handleSubmit = (e) => {
        e.preventDefault();
        const formData = new FormData(e.currentTarget);
        const entries = Object.fromEntries(formData);

        const combinedData = {
            ...data,
            phi_angle_settings: phiAngleSettings,
            psi_angle_settings: psiAngleSettings
        };
        axios
            .post(UPDATE_URL, combinedData)
            .then((response) => {
                console.log(response.data);
                const updatedData = {
                    ...combinedData,
                    ...response.data,
                };

                onSubmit(updatedData);
                navigate("/display_model", {state: {data1: updatedData}});
            })
            .catch((error) => {
                console.log(error);
                return toast.error(error.message);
            });  
    }



    return (
        <>
            <h2>Select residues to target and constrain</h2>
            <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
                <div id="angleSelect">
                    <h3>Phi angles</h3>
                    {values.map((num) => (
                        <div key={`phi_${num}`} id="individualAngle">
                            <label>Phi angle {num}: </label>
                            <select value={phiAngleSettings[num]} onChange={(e) => handlePhiChange(num, e.target.value)}>
                            <option value="default">Default</option>
                            <option value="constrained">Constrained</option>
                            <option value="targeted">Targeted</option>
                            </select>
                        </div>
                    ))}
                </div>
                <div id="angleSelect">
                    <h3>Psi angles</h3>
                    {values.map((num) => (
                        <div key={`psi_${num}`} id="individualAngle">
                            <label>Psi angle {num}: </label>
                            <select value={psiAngleSettings[num]} onChange={(e) => handlePsiChange(num, e.target.value)}>
                            <option value="default">Default</option>
                            <option value="constrained">Constrained</option>
                            <option value="targeted">Targeted</option>
                            </select>
                        </div>
                    ))}
                </div>
            <button>View model</button>
            </form>
        </>
    )
}

export default(FormBackend);