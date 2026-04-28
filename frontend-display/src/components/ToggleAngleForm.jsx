import axios from "axios";
import {toast} from "react-toastify";
import {useNavigate } from "react-router-dom";

const UPDATE_URL = "http://127.0.0.1:5000/update-angles";

const ToggleAngleForm = () => {
    const navigate = useNavigate();

    const handleSubmit = (e) => {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const entries = Object.fromEntries(data);
    axios
        .post(UPDATE_URL, entries)
        .then((response) => {
            navigate("/toggled_model", {state: {data1: response.data}});
        })
        .catch((error) => {
            console.log(error);
            return toast.error(error.message);
        });  
    }

    return <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
        <p>Put a 0 in boxes that you don't want to use.</p>
        <p>Segment beginning: </p>
            <input type="number" name="segbeg" id="segbeg" required></input>
        <p>Segment end: </p>
            <input type="number" name="segend" id="segend" required></input>
        <label className="form-label">
            Phi Angle to target:
            <input id="phiAngleTX1" name="phiAngleTX1" type="number" required></input>
            <input id="phiAngleTY1" name="phiAngleTY1" type="number" required></input>
            <input id="phiAngleTX2" name="phiAngleTX2" type="number" required></input>
            <input id="phiAngleTY2" name="phiAngleTY2" type="number" required></input>
            <input id="phiAngleTX3" name="phiAngleTX3" type="number" required></input>
            <input id="phiAngleTY3" name="phiAngleTY3" type="number" required></input>
            <input id="phiAngleTX4" name="phiAngleTX4" type="number" required></input>
            <input id="phiAngleTY4" name="phiAngleTY4" type="number" required></input>
        </label>
        <label className="form-label">
            Psi Angle to target:
            <input id="psiAngleTX1" name="psiAngleTX1" type="number" required></input>
            <input id="psiAngleTY1" name="psiAngleTY1" type="number" required></input>
            <input id="psiAngleTX2" name="psiAngleTX2" type="number" required></input>
            <input id="psiAngleTY2" name="psiAngleTY2" type="number" required></input>
            <input id="psiAngleTX3" name="psiAngleTX3" type="number" required></input>
            <input id="psiAngleTY3" name="psiAngleTY3" type="number" required></input>
            <input id="psiAngleTX4" name="psiAngleTX4" type="number" required></input>
            <input id="psiAngleTY4" name="psiAngleTY4" type="number" required></input>
        </label>
        <label className="form-label">
            Phi Angle to constrain:
            <input id="phiAngleC1" name="phiAngleC1" type="number" required></input>
            <input id="phiAngleC2" name="phiAngleC2" type="number" required></input>
        </label> 
        <label className="form-label">
            Psi Angle to constrain:
            <input id="psiAngleC1" name="psiAngleC1" type="number" required></input>
            <input id="psiAngleC2" name="psiAngleC2" type="number" required></input>
        </label>
        <button>Update model</button>
    </form>
}

export default ToggleAngleForm;