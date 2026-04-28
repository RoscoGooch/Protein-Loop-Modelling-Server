import { useLocation } from "react-router-dom";
import {useRef, useEffect, useState} from "react";
import parse from 'html-react-parser';
import axios from "axios";
import {toast} from "react-toastify";

const MODEL_URL = "http://127.0.0.1:5000/get-pdb-file";

const ProteinModelView = () => {
    const containerRef = useRef(null);

    const [pdbdata, setPdbdata] = useState(null);

    useEffect(() => {
        axios.post(MODEL_URL).then((response) => {
            setPdbdata(response.data);
        })
        .catch((error) => {
            console.log(error);
            return toast.error(error.message);
        });  
    }, []);
    
    useEffect(() => {
    var Info = {
        height: 400,
        width: 600,
        script: 'load DATA "pdb"\n' + pdbdata + '\nEND "pdb";',
        use: "HTML5",
        j2sPath: "src/j2s",
    };

    containerRef.current.innerHTML = window.Jmol.getAppletHtml("myJmol", Info);

    })

    return (
    <div id='protein-model'>
        <h2>Protein Model Viewer</h2>
        <div ref={containerRef} />
        <p>Powered by JSMol</p>
    </div>
    );
}




export default ProteinModelView;