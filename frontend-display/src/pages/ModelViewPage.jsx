import ProteinModelBackend from "../components/ProteinModelBackend";
import ModelStatsBox from "../components/ModelStatsBox";
import { useLocation, useNavigate } from "react-router-dom";
import {useState, useEffect} from "react";
import ForceLogin from "../components/ForceLogin";
import { useAuth0 } from "@auth0/auth0-react";

const ModelViewPage = (data) => {
    const {isAuthenticated} = useAuth0();

    const navigate = useNavigate();

    function goToLoad() {
        navigate("/load_model");
    }
    const location = useLocation();

    let modelData = location.state?.data1;
    console.log(modelData);

    const [modelReady, setModelReady] = useState(false);

    if(isAuthenticated == true){
    return (
        <div id='model-display'>
            <ProteinModelBackend data={modelData} onReady={() => setModelReady(true)}/>
            {modelReady && (<ModelStatsBox data={modelData}/>)}
            <button onClick={goToLoad}>Change chain and code</button>
        </div>
    )
    }
    else{
        return(
        <>
        <ForceLogin/>
        </>
        )
    }
}

export default ModelViewPage;