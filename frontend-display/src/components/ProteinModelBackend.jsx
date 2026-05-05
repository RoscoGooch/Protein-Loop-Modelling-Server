import { useLocation } from "react-router-dom";
import {useRef, useEffect, useState} from "react";
import parse from 'html-react-parser';
import axios from "axios";
import {toast} from "react-toastify";

function ProteinModelBackend({data, onReady}) {
    const containerRef = useRef(null);
    const { endPdbdata, loading } = useEndProteinData(data);
    const [modelLoaded, setModelLoaded] = useState(false);
    
    useEffect(() => {
        if (!endPdbdata) return;

        setModelLoaded(false);

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

    }, [endPdbdata]);

    return (
    <div id='protein-model'>
        <h2>Protein Model Viewer</h2>
        {(loading || !modelLoaded) && (
            <div className="loader">
                Loading protein...
            </div>
        )}
        <div ref={containerRef} style={{ display: modelLoaded ? "block" : "none" }}/>
        <p>Powered by JSMol</p>
    </div>
    );
}

const useEndProteinData = (data) => {
    const ANGLE_URL = "http://127.0.0.1:5000/update-angles";
    const [endPdbdata, setEndPdbdata] = useState(null);
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
        })
        .catch((error) => {
            toast.error(error.message);
        })
        .finally(() => {
            setDataLoading(false);
        });

    }, [data]);

    return {endPdbdata, loading};
};

export default ProteinModelBackend;