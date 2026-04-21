import { useLocation } from "react-router-dom";
import {useRef, useEffect} from "react";
import parse from 'html-react-parser';

const ProteinModelView = () => {
    const containerRef = useRef(null);

    useEffect(() => {
    var Info = {
        height: 400,
        width: 600,
        script: "load $caffeine",
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