import axios from "axios";
import {toast} from "react-toastify";

const UPDATE_URL = "http://127.0.0.1:5000/update-angles";

const ToggleAngleForm = () => {
    const handleSubmit = (e) => {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const entries = Object.fromEntries(data);
    axios
        .post(UPDATE_URL, entries)
        .then((response) => {
            console.log(response.data);
        })
        .catch((error) => {
            console.log(error);
            return toast.error(error.message);
        });  
    }

    return <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
        <label className="form-label">
            Phi Angle:
            <input id="phiAngle" type="text"></input>
        </label> 
        <label className="form-label">
            Psi Angle:
            <input id="psiAngle" type="text"></input>
        </label>
        <button>Update model</button>
    </form>
}

export default ToggleAngleForm;