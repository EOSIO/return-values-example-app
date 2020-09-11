import React, { useState } from 'react';
import { Api } from 'eosjs';

import Error from '../Error';

interface SumActionProps {
    api: Api | undefined;
}

const SumAction: React.FC<SumActionProps> = ({ api }: SumActionProps) => {
    const [numbers, setNumbers] = useState<{ first: number|'', second: number|'' }>({ first: 0, second: 0})
    const [error, setError] = useState<string>('');
    const [result, setResult] = useState<number|undefined>();

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (!e.target.value) return setNumbers({...numbers, [e.target.name]: '' });
        const value = Math.max(Number(e.target.min), Math.min(Number(e.target.max), Number(e.target.value)));
        setNumbers({...numbers, [e.target.name]: value });
    };

    const handleKeyPress = async (e: React.KeyboardEvent<HTMLInputElement>) => {
        if(e.key !== 'Enter') return;
        await sum();
    };

    const sum = async () => {
        setError('');
        if (api === undefined) {
            return setError('Unexpected error: Api object is not set.')
        }
        try {
            const transactionResult = await api.transact({
                actions: [{
                    account: 'returnvalue',
                    name: 'sum',
                    authorization: [{
                        actor: 'returnvalue',
                        permission: 'active',
                    }],
                    data: {
                        valueA: numbers.first,
                        valueB: numbers.second
                    }
                }]
            }, {
                blocksBehind: 3,
                expireSeconds: 30
            }) as any;
            setResult(transactionResult.processed.action_traces[0].return_value_data);
        } catch (e) {
            if (e.json) {
                setError(JSON.stringify(e.json, null, 4));
            } else {
                setError(e + '');
            }
        }
    };

    const retry = () => {
        setResult(undefined);
    };

    return (
        <div className='contract-container'>
            <div className='contract-header-container'>
                <div className='contract-header'>Addition</div>
                {result === undefined && <button className='button' onClick={e => sum()}>Get Result</button>}
                {typeof result === 'number' && <button className='button' onClick={e => retry()}>Retry</button>}
            </div>
            <div className='equation'>
                <div className='input-container'>
                    <input
                        className='input'
                        name='first'
                        type='number'
                        min={0}
                        max={99999}
                        disabled={!!result}
                        value={numbers.first}
                        onChange={handleChange}
                        onKeyPress={handleKeyPress}>
                    </input>
                </div>
                <div className='symbol'>+</div>
                <div className='input-container'>
                    <input
                        className='input'
                        name='second'
                        type='number'
                        min={0}
                        max={99999}
                        disabled={!!result}
                        value={numbers.second}
                        onChange={handleChange}
                        onKeyPress={handleKeyPress}>
                    </input>
                </div>
                <div className='symbol'>=</div>
                {result === undefined && <div className='result'>?</div>}
                {typeof result === 'number' && <div className='result'>{result}</div>}
            </div>
            
            {error && <Error error={error} />}
        </div>
    );
};

export default SumAction;