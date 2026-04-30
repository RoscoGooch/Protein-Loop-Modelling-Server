import { useState } from "react";
import axios from "axios";
import {toast} from "react-toastify";
import {useNavigate } from "react-router-dom";


function FormBackend() {
    const [step, setStep] = useState(1);
    const [formData, setFormData] = useState({});

    const handleStepOneSubmit = (data) => {
        setFormData((prev) => ({ ...prev, ...data }));
        setStep(2);
    };

    const handleStepTwoSubmit = (data) => {
        setFormData((prev) => ({ ...prev, ...data }));
        setStep(3);
    };

    return (
        <>
            {step === 1 && <GetChain onSubmit={handleStepOneSubmit} />}
            {step === 2 && <GetAngles data={formData} onSubmit={handleStepTwoSubmit}/>}
            {step === 3 && <ChooseTargetAngles data={formData}/>}
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
        <label className="form-label">
            <p>PDBCode of start file:</p>
            <input id="pdbcode" name="pdbcode" type="string" required></input>
        </label>
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
        <button>Submit details</button>
    </form>
}

const ChooseTargetAngles = ({ data, onSubmit }) => {
    const segbeg = Number(data.segbeg);
    const segend = Number(data.segend);

    const [targetPhiAngles, setSelectedPhiTargets] = useState([]);
    const [constrainedPhiAngles, setSelectedPhiConstraints] = useState([]);
    const [targetPsiAngles, setSelectedPsiTargets] = useState([]);
    const [constrainedPsiAngles, setSelectedPsiConstraints] = useState([]);

    const handlePhiTargetChange = (event) => {
        setSelectedPhiTargets((prev) => {
            if (prev.includes(event.target.value)) {
                return prev.filter(item => item !== event.target.value);
            } else {
                return [...prev, event.target.value];
            }
        });
        
    };

    const handlePhiConstraintChange = (event) => {
        setSelectedPhiConstraints((prev) => {
            if (prev.includes(event.target.value)) {
                return prev.filter(item => item !== event.target.value);
            } else {
                return [...prev, event.target.value];
            }
        });
    };

    const handlePsiTargetChange = (event) => {
        setSelectedPsiTargets((prev) => {
            if (prev.includes(event.target.value)) {
                return prev.filter(item => item !== event.target.value);
            } else {
                return [...prev, event.target.value];
            }
        });
        
    };

    const handlePsiConstraintChange = (event) => {
        setSelectedPsiConstraints((prev) => {
            if (prev.includes(event.target.value)) {
                return prev.filter(item => item !== event.target.value);
            } else {
                return [...prev, event.target.value];
            }
        });
    };

    const values = Array.from({ length: segend - segbeg - 1}, (_, i) => (segbeg + 1 + i));

    const navigate = useNavigate();

    const handleSubmit = (e) => {
        e.preventDefault();
        const formData = new FormData(e.currentTarget);
        const entries = Object.fromEntries(formData);
        
        const combinedData = {
            ...data,
            ...entries,
        };
        navigate("/display_model", {state: {data1: combinedData}});
    }


    return (
        <>
            <h2>Select angles to target and constrain</h2>
            <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
            <h3>Phi Angles to target to values in closed structure:</h3>
            <select multiple onChange={handlePhiTargetChange} value={targetPhiAngles} className='angleSelectBox'>
                {values.map((num, index) => (
                <option key={num} value={num}>
                    {num}
                </option>
                ))}
            </select>
            <h3>Phi Angles to constrain to values in open structure:</h3>
            <select multiple onChange={handlePhiConstraintChange} value={constrainedPhiAngles} className='angleSelectBox'>
                {values.map((num, index) => (
                <option key={num} value={num}>
                    {num}
                </option>
                ))}
            </select>
            <h3>Psi Angles to target to values in closed structure:</h3>
            <select multiple onChange={handlePsiTargetChange} value={targetPsiAngles} className='angleSelectBox'>
                {values.map((num, index) => (
                <option key={num} value={num}>
                    {num}
                </option>
                ))}
            </select>
            <h3>Psi Angles to constrain to values in open structure:</h3>
            <select multiple onChange={handlePsiConstraintChange} value={constrainedPsiAngles} className='angleSelectBox'>
                {values.map((num, index) => (
                <option key={num} value={num}>
                    {num}
                </option>
                ))}
            </select>
            <button>View model</button>
            </form>
        </>
    )
}

export default(FormBackend);