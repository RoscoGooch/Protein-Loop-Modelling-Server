import ProteinModelView from "../components/ProteinModelView";
import ToggleAngleForm from "../components/ToggleAngleForm";
import { useLocation } from "react-router-dom";
import { Navigate } from "react-router-dom";

const ModelViewPage = () => {
    function goToDisplay() {
        navigate("/display_model");
    }
    const location = useLocation();

    let modelData = location.state?.data1;
    
    return (
    <div id='model-display'>
        <ProteinModelView data={modelData}/>
        <ToggleAngleForm/>
        <button onClick={goToDisplay}>Change chain and code</button>
    </div>
    )
}

export default ModelViewPage;