import { useLocation } from "react-router-dom";
import {useRef, useEffect, useState} from "react";
import parse from 'html-react-parser';
import axios from "axios";
import {toast} from "react-toastify";

const DefaultProtein = ({data}) => {
    const containerRef = useRef(null);
    
    useEffect(() => {
    var Info = {
        height: 400,
        width: 600,
        script: `load =${data}`,
        use: "HTML5",
        j2sPath: "src/j2s",
    };

    containerRef.current.innerHTML = window.Jmol.getAppletHtml("myJmol", Info);

    })

    return (
    <div id='protein-model'>
        <h2>Protein Model Viewer </h2>
        <div ref={containerRef} />
        <p>Powered by JSMol</p>
    </div>
    );
}

export default DefaultProtein;