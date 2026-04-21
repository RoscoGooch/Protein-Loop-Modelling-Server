import {useState} from "react";

const RotateSlider = () => {
    const [rotateSlider, setRotateSlider] = useState("");

    const rotateModel = (e) => {
        console.log(` before .. ${rotateSlider}`);
        setRotateSlider(e.target.value);
        console.log(` after .. ${rotateSlider}`);
    };

    return <>
    <label className="slider-label">
        Rotate Model
        <input id="rotateSlider" type="range" min="0" max="360" value="180" className="slider" onChange={rotateModel}/>
    </label>

    </>
}

export default RotateSlider;