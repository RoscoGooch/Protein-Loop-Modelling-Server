import ProteinModelView from "../components/ProteinModelView";
import RotateSlider from "../components/RotateSlider";
import ToggleAngleForm from "../components/ToggleAngleForm";

const ModelDisplayPage = () => {
    return (
    <>
        <h1>ModelDisplayPage</h1>
        <ProteinModelView/>
        <ToggleAngleForm/>
        <ZoomSlider/>
        <RotateSlider/>
    </>
    )
}

export default ModelDisplayPage;