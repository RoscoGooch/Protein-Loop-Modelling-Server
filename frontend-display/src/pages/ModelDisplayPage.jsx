import ProteinModelView from "../components/ProteinModelView";
import ToggleAngleForm from "../components/ToggleAngleForm";
import { useLocation } from "react-router-dom";

const ModelDisplayPage = () => {
    /*const location = useLocation();

    let modelData = location.state?.data1;

    console.log(modelData);

    let chain = modelData[0];
    let code = modelData[1];
    let segbeg = modelData[2];
    let segend = modelData[3];
    
    return (
    <div id='model-display'>
        <h1>View and update model for code {code} and chain {chain}</h1>
        <ProteinModelView code={code} chain={chain}/>
        <ToggleAngleForm/>
        <ZoomSlider/>
        <RotateSlider/>
        <h3>Segment beginning = {segbeg}</h3>
        <h3>Segment end = {segend}</h3>
    </div>
    )*/

    return(
    <div id='model-display'>
        <ProteinModelView/>
        <ToggleAngleForm/>
    </div>
    )
}

export default ModelDisplayPage;