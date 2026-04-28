import ProteinModelView from "../components/ProteinModelView";
import ToggleAngleForm from "../components/ToggleAngleForm";
import { useLocation } from "react-router-dom";

const ModelDisplayPage = () => {
    const location = useLocation();

    let modelData = location.state?.data1;

    console.log(modelData);

    let code = modelData[0];
    let chain = modelData[1];
    let segbeg = modelData[2];
    let segend = modelData[3];
    let pdbfile = modelData[4];
    
    return (
    <div id='model-display'>
        <h1>View and update model for code {code} and chain {chain}</h1>
        <ToggleAngleForm/>
        <h3>Segment beginning = {segbeg}</h3>
        <h3>Segment end = {segend}</h3>
    </div>
    )
}

export default ModelDisplayPage;