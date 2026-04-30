import { createBrowserRouter } from 'react-router-dom';
import { HomeLayoutPage, ErrorPage, IndexPage, ModelLoadPage, ModelViewPage} from './pages/index';

export const router = createBrowserRouter([
    {
        path: "/",
        element: <HomeLayoutPage />,
        errorElement: <ErrorPage />,
        children: [
            {
                index: true,
                element: <IndexPage />
            },
            {
                path: "/load_model",
                element: <ModelLoadPage />
            },
            {   path: "/display_model",
                element: <ModelViewPage />
            }
        ]    
    },
]);    