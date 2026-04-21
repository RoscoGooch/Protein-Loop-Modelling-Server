import { useLocation } from "react-router-dom";
import {useRef} from "react";
import parse from 'html-react-parser';

const ProteinModelView = (code, chain) => {
    const containerRef = useRef(null);

    var Info = {
                height: 300,
                width: 300,
                script: "load $caffeine",
                use: "HTML5",
                j2sPath: "j2s",
                serverURL: "php/jsmol.php"
    };

    window.Jmol.getApplet("myJmol", Info);
    containerRef.current.innerHTML = window.Jmol.getAppletHtml("myJmol");

    return (<div id='protein-model' ref={containerRef} />);
}

export default ProteinModelView;