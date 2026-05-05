import ProteinModelBackend from "../components/ProteinModelBackend";
import ModelStatsBox from "../components/ModelStatsBox";
import { useLocation, useNavigate } from "react-router-dom";
import {useState, useEffect} from "react";
import TopHeader from "../components/TopHeader";

const ModelViewPage = (data) => {
    const navigate = useNavigate();

    function goToLoad() {
        navigate("/load_model");
    }
    const location = useLocation();

    let modelData = location.state?.data1;
    console.log(modelData);

    const [modelReady, setModelReady] = useState(false);
    
    return (
    <div id='model-display'>
        <TopHeader/>
        <ProteinModelBackend data={modelData} onReady={() => setModelReady(true)}/>
        {modelReady && (<ModelStatsBox data={modelData}/>)}
        <button onClick={goToLoad}>Change chain and code</button>
    </div>
    )
}

export default ModelViewPage;