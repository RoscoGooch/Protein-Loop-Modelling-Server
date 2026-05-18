import { useLocation } from "react-router-dom";
import {useRef, useEffect, useState} from "react";
import parse from 'html-react-parser';
import axios from "axios";
import {toast} from "react-toastify";

function SampleModelContainer({data}) {
    const pdbUrl = "/SampleModelCode.pdb";
    const containerRef = useRef(null);
    
    useEffect(() => {
        containerRef.current.innerHTML = "";

        const Info = {
            height: 400,
            width: 600,
            script: `
                load "${pdbUrl}";
                animation on;
                animation mode loop;
                animation fps 5;
                `,
            use: "HTML5",
            j2sPath: "src/j2s",
            };

        containerRef.current.innerHTML = window.Jmol.getAppletHtml("myJmol", Info);

    }, [pdbUrl]);

    return (
    <div id='sample-protein-model'>
        <div className='sample-protein-model' ref={containerRef}/>
    </div>
    );
}

export default SampleModelContainer;