import {useState} from "react";

const ZoomSlider = () => {
    const [zoomSlider, setZoomSlider] = useState("");

    const zoomModel = (e) => {
        console.log(` before .. ${zoomSlider}`);
        setZoomSlider(e.target.value);
        console.log(` after .. ${zoomSlider}`);
    };

    return <>
    <label className="slider-label">
        Zoom Model
        <input id="zoomSlider" type="range" min="0" max="5000" value="1500" className="slider" onChange={zoomModel}/>
    </label>
    </>
}

export default ZoomSlider;