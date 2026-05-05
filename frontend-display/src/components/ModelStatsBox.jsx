import { useLocation } from "react-router-dom";
import {useRef, useEffect, useState} from "react";
import parse from 'html-react-parser';
import axios from "axios";
import {toast} from "react-toastify";

function ModelStatsBox({data}) {
    const ANGLE_URL = "http://127.0.0.1:5000/get-model-startend";
    const [angleData, setAngleData] = useState(null);

    //get relevant features out of data
    const segbeg = Number(data.segbeg);
    const segend = Number(data.segend);
    const phiSettings = data.phi_angle_settings;
    const psiSettings = data.psi_angle_settings;

    useEffect(() => {
            axios.post(ANGLE_URL).then((response) => {
                console.log(response.data);
                setAngleData(response.data);
            })
            .catch((error) => {
                console.log(error);
                return toast.error(error.message);
            });  
    }, []);

    const startPhiAngles = angleData?.start_model_phi_angles;
    const startPsiAngles = angleData?.start_model_psi_angles;
    const endPhiAngles = angleData?.end_model_phi_angles;
    const endPsiAngles = angleData?.end_model_psi_angles;

    //create stats table with relevant data

    if (!angleData) {
        return <div>Loading stats...</div>;
    }   

    return(
        <>
        <h2>Model statistics: </h2>
        <p>Code: {data.pdbcode}</p>
        <p>Chain: {data.start_chain}</p>
        <p>Segment start: {segbeg} | Segment end: {segend}</p>
        <table id='statsTable'>
            <thead>
                <tr>
                    <th>Residue Number</th>
                    <th>Phi Setting</th>
                    <th>Start Phi Angle</th>
                    <th>End Phi Angle</th>
                    <th>Psi Setting</th>
                    <th>Start Psi Angle</th>
                    <th>End Psi Angle</th>
                </tr>
            </thead>

            <tbody>
                {Object.keys(phiSettings || {}).map((resnum) => {
                    const index = resnum - segbeg;

                    return (
                        <tr key={resnum}>
                        <td>{resnum}</td>

                        <td>{phiSettings[resnum]}</td>
                        <td>{Math.round(startPhiAngles[index])}</td>
                        <td>{Math.round(endPhiAngles[index])}</td>

                        <td>{psiSettings[resnum]}</td>
                        <td>{Math.round(startPsiAngles[index])}</td>
                        <td>{Math.round(endPsiAngles[index])}</td>
                    </tr>
                    )
                })}
            </tbody>
        </table>
        </>
    )
}

export default ModelStatsBox;