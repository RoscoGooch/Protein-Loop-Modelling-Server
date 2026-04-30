import ProteinModelView from "../components/ProteinModelView";
import { useLocation } from "react-router-dom";
import { Navigate } from "react-router-dom";
import DefaultProtein from "../components/DefaultProtein";

const ModelViewPage = (data) => {
    function goToLoad() {
        navigate("/load_model");
    }
    const location = useLocation();

    let modelData = location.state?.data1;
    console.log(modelData);

    let pdbcode='1adg';
    
    return (
    <div id='model-display'>
        <DefaultProtein data={pdbcode}/>
        <button onClick={goToLoad}>Change chain and code</button>
    </div>
    )
}

export default ModelViewPage;