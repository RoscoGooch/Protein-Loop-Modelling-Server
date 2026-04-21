import axios from "axios";
import {toast} from "react-toastify";
import {useNavigate} from "react-router-dom";

const MODEL_URL = "http://127.0.0.1:5000/load-model";

const SubmitModel = () => {
    const navigate = useNavigate();

    const handleSubmit = (e) => {
    e.preventDefault();
    const data = new FormData(e.currentTarget);
    const entries = Object.fromEntries(data);
    console.log(entries)
    axios
        .post(MODEL_URL, entries)
        .then((response) => {
            console.log(response.data);
            navigate("/displayModel", {state: {data1: response.data}});
            return toast.success("Successfully submitted model!");
        })
        .catch((error) => {
            console.log(error);
            return toast.error(error.message);
        });  
    }

    return <form id="modelSubmit" className="form" onSubmit={handleSubmit}>
        <p>Chain: </p>
        <input type="char" name="chain" id="chain" required></input>
        <p>Code: </p>
        <input type="string" name="pdbcode" id="pdbcode" required></input>
        <p>Segment beginning: </p>
        <input type="int" name="segbeg" id="segbeg" required></input>
        <p>Segment end: </p>
        <input type="int" name="segend" id="segend" required></input>
        <button type="submit">Submit model</button>
    </form>
    
}

export default SubmitModel;