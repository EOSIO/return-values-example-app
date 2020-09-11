import React from 'react';

interface ErrorProps {
    error: string;
}

const Error: React.FC<ErrorProps> = ({ error }: ErrorProps) => {
    return (
        <div className='error-container'>
            <div className='errorHeader'>Error:</div>
            <div className='error'>{error}</div>
        </div>
    );
};

export default Error;