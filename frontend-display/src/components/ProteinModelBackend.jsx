import { useLocation } from "react-router-dom";
import {useRef, useEffect, useState} from "react";
import parse from 'html-react-parser';
import axios from "axios";
import {collapseToast, toast} from "react-toastify";

function ProteinModelBackend({data, onReady}) {
    const containerRef = useRef(null);

    const reportRef = useRef(null);
    const { endPdbdata, collisionsReport, loading } = useEndProteinData(data);
    const [modelLoaded, setModelLoaded] = useState(false);
    
    useEffect(() => {
        if (!endPdbdata || !collisionsReport) return;

        setModelLoaded(false);

        containerRef.current.innerHTML = "";

        const Info = {
            height: 400,
            width: 600,
            script: `
                load DATA "pdb" "${endPdbdata}" END "pdb";
                animation on;
                animation mode loop;
                animation fps 5;
                `,
            use: "HTML5",
            j2sPath: "src/j2s",
            readyFunction: () => {
                setModelLoaded(true);
                if (onReady) onReady();
            }   
            };

        containerRef.current.innerHTML = window.Jmol.getAppletHtml("myJmol", Info);

        if (collisionsReport.collisions.length > 0){
            toast.warn("Collision identified in this model");
        }

    }, [endPdbdata, collisionsReport]);

    return (
    <div id='protein-model'>
        <h2>Protein Model Viewer</h2>
        {(loading || !modelLoaded) && (
            <div className="loader">
                Loading protein...
            </div>
        )}
        <div className='protein-model' ref={containerRef} style={{ display: modelLoaded ? "block" : "none" }}/>
        <p>Powered by JSMol</p>
    </div>
    );
}

const useEndProteinData = (data) => {
    const ANGLE_URL = "http://127.0.0.1:5000/update-angles";
    const COLLISION_URL = "http://127.0.0.1:5000/collision-check";
    const [endPdbdata, setEndPdbdata] = useState(null);
    const [collisionsReport, setCollisionsReport] = useState(null);
    const [loading, setDataLoading] = useState(false);


    useEffect(() => {
        if (!data) return;
        setDataLoading(true);

        axios.post(ANGLE_URL, data, {
            responseType: "blob"
        })
        .then(async (response) => {
            const text = await response.data.text();
            setEndPdbdata(text);

            return axios.get(COLLISION_URL);
        })
        .then((response) => {
            const collisionsReport = (response.data);
            setCollisionsReport(collisionsReport);
            console.log(collisionsReport);
        })
        .catch((error) => {
            const data = error.response?.data;
            const message = data?.error;

            toast.error(message);
            return;
        })
        .finally(() => {
            setDataLoading(false);
        });

    }, [data]);

    return {endPdbdata, collisionsReport, loading};
};

export default ProteinModelBackend;